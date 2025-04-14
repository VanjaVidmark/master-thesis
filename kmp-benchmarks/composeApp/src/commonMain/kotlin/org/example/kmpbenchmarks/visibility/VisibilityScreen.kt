import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.layout.ContentScale
import org.jetbrains.compose.resources.painterResource
import kmp_benchmarks.composeapp.generated.resources.Res
import kmp_benchmarks.composeapp.generated.resources.img10mb
import org.example.kmpbenchmarks.visibility.VisibilityController

@Composable
fun VisibilityScreen(onDone: () -> Unit) {
    val isRunning by VisibilityController.isRunning.collectAsState()

    val infiniteTransition = rememberInfiniteTransition()
    val alpha by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1000, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        )
    )

    Box(modifier = Modifier.fillMaxSize()) {
        if (isRunning) {
            Image(
                painter = painterResource(Res.drawable.img10mb),
                contentDescription = "Example Image",
                contentScale = ContentScale.Crop,
                modifier = Modifier
                    .fillMaxSize()
                    .alpha(alpha)
            )
        }
    }

    LaunchedEffect(isRunning) {
        if (!isRunning) {
            onDone()
        }
    }
}
