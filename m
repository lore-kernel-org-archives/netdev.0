From: Pasi Sjoholm <ptsjohol@cc.jyu.fi>
Subject: Re: strange network performance degradation 2.6.8-rc3-mm1 ->
 2.6.8-rc4-mm1
Date: Sun, 15 Aug 2004 20:16:29 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0408152015220.29477-100000@silmu.st.jyu.fi>
References: <20040815095900.GA2846@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Jurriaan <thunder7@xs4all.nl>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040815095900.GA2846@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 15 Aug 2004, Francois Romieu wrote:

> Ok, the early read of the interrupt status register is the culprit.
> If M.Sjoholm's setup works fine, I'll forward the update for inclusion
> in -mm/-netdev.

Tested these patches and everything worked ok.=20

--
Pasi Sj=F6holm
