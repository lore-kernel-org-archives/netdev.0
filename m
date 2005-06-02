From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: R8169 from U.S.Robotics not found by driver
Date: Thu, 2 Jun 2005 20:34:56 +0200
Message-ID: <20050602183456.GA5606@electric-eye.fr.zoreil.com>
References: <3BDD1137DBC16749ACF2C93F82FCA98DA107D2@s1ms3.D01.arc.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux r8169 crew <netdev@oss.sgi.com>, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kutschera Peter <Peter.Kutschera@arcs.ac.at>
Content-Disposition: inline
In-Reply-To: <3BDD1137DBC16749ACF2C93F82FCA98DA107D2@s1ms3.D01.arc.local>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kutschera Peter <Peter.Kutschera@arcs.ac.at> :
[...]
> If you have any tips please let me know.

Upgrade to (at your option):
- 2.6.12-rc5 + Jeff Garzik's r8169 git branch;
- 2.6.12-rc5-mm2.

Both contain the latest r8169 driver. It will handle USR hardware.
If you manage to kill it, please report it.

Would your setup allow to test the driver in the Mpps range by any luck ?

--
Ueimor
