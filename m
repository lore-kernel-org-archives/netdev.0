From: Parag Nemade <cranium2003@yahoo.com>
Subject: HELP ipt_hook: happy cracking message
Date: Mon, 26 Apr 2004 08:12:20 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040426151220.85059.qmail@web41403.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
        netfilter <netfilter-devel@lists.netfilter.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: kernerl mail <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi,
        i modified kernel so that it will create
/proc/net/myproc file entry.
the function of this entry is to crate a 16 byte char
string from random no.s
i used net_srandom and net_random and sys_time for
that puspose. the problem is that i write program to
generate string after 120 seconds but it is changing
contents of myproc file every seconds. what can i do?
 Also i am getting ipt_hook: happy cracking. message
again and again why?
regards,
parag.


=09
	=09
__________________________________
Do you Yahoo!?
Yahoo! Photos: High-quality 4x6 digital prints for 25=A2
http://photos.yahoo.com/ph/print_splash
