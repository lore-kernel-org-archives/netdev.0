From: "Sean" <seanlkml@rogers.com>
Subject: Trivial cosmetic unimportant issue (urgent)
Date: Wed, 23 Jul 2003 15:12:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <000901c3514e$59697bd0$7f0a0a0a@lappy7>
Reply-To: "Sean" <seanlkml@rogers.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi folks,

      Just a few days uptime and sysfs is reporting that i've transfered a _negative_ number of bytes!  Any chance this could be
unsigned output instead?    The display is created in a common net_device_stat_show but none of the others values should go negative
either.

Cheers,
Sean
