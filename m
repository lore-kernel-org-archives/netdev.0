From: =?ISO-8859-2?Q?Igor_Maravi=E6?= <igorm@etf.rs>
Subject: MPLS for Linux kernel
Date: Sun, 20 Nov 2011 22:59:29 +0100
Message-ID: <CAFdo_mWE8wMB6QJt_DPi9Ou9OiayzV48URDq7KhKf+q8OfP+Gw@mail.gmail.com>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,
I've been working on implementation of MPLS for Linux kernel, for a
some time now.
I continued the work of James Leu
(https://sourceforge.net/projects/mpls-linux/) and used some fixes of
Jorge Boncompte
(http://mpls-linux.git.sourceforge.net/git/gitweb.cgi?p=3Dmpls-linux/ne=
t-next;a=3Dshortlog;h=3Drefs/heads/net-next-mpls).

I fixed a lot of bugs, so now it can be compiled and run with all
Kernel Hacking options enabled.
My code could be found on this sites:

https://github.com/i-maravic/MPLS-Linux
https://github.com/i-maravic/iproute2

Any feedback is appreciated :)

On Dave's blog I read that MPLS is one of the things that should be
implemented in to the Linux kernel.
What is the procedure to do that with this code?
BR
Igor Maravi=C4=87
