From: Christian Schmid <webmaster@rapidforum.com>
Subject: Annoying bug with many sockets.
Date: Mon, 21 Feb 2005 01:05:47 +0100
Message-ID: <421925DB.2060602@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.

This is really annoying. With 3500 sockets onwards, linux 2.6.10 completely lags. This is a bug and 
I am not willing to buy new servers just because linux has a BUG. tcp_mem _rmem and _wmem have been 
set to 1024000 for testing but this doesnt help as well. so whats WRONG there... please?

Best regards,
Chris
