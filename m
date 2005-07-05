From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: Msi-X on Opterons?
Date: Tue, 5 Jul 2005 11:31:02 -0700
Message-ID: <200507051831.j65IV6xS005692@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>,
        "'Raghavendra Koushik'" <raghavendra.koushik@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@vger.kernel.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Did anyone had any luck getting MSI-X working on Opteron platforms?
The newer 8132-based systems support MSI-X, but we could not get it working
with our card there.
It works fine on Xeon systems, I wonder if the implementation is
Xeon-centric...
