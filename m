From: Lewis Adam-CAL022 <Adam.Lewis@motorola.com>
Subject: ksymoops can't see symbols in /proc/ksyms
Date: Tue, 14 Sep 2004 19:47:48 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <FD52892BD296D71183B400065BFCB6900F1AA7C7@il02exm12>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I run ksymoops passing it an oops file.  It complains that the modules have no exported symbols, and yet if I cat /proc/ksyms they are all there.  Anybody know what is wrong?
