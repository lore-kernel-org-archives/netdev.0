From: Sergey Ryazanov <ryazanov.s.a@gmail.com>
Subject: Re: [PATCH 09/28] Remove ATHEROS_AR231X
Date: Fri, 5 Sep 2014 15:12:55 +0400
Message-ID: <CAHNKnsRipRHicKOUW4dCutD1-sUG6qPnP2QuOveH_t1MFX9XgQ@mail.gmail.com>
References: <1391971686-9517-1-git-send-email-richard@nod.at>
 <1391971686-9517-10-git-send-email-richard@nod.at>
 <52F7D480.1050106@hauke-m.de> <52F7DF21.70207@nod.at>
 <CAHNKnsS7Mv4ZhBWZa53go9L9nZimJ7_FG5HFJ9C3kkGMAEz-mA@mail.gmail.com>
 <52F8C373.9060108@rempel-privat.de>
 <CAHNKnsQF5Hdf3JT91moPraRQzn4kMpdD2NSiJ7b30wQhS1W4MA@mail.gmail.com>
 <CAGVrzcYnECx5Q=i+m6qZn29y4JALDpw5SWoUNP-S6HgPR3_ygQ@mail.gmail.com>
 <CAHNKnsRACSo=DfOyiHxqV3acv_wfZmz4tMnYAW0wo4OCibwdfA@mail.gmail.com>
 <CAHNKnsRQp7WLSJNAXEYPTd=qs1DquOfNgKtHES-Utvcy1=FEgQ@mail.gmail.com>
 <20140213201421.GJ22203@tuxdriver.com>
 <1397581703.8212.5.camel@x220>
 <CAHNKnsQQ42-XnXrubHAy4PF3H2ynbGDdSMP7MvDS_1aRozYF=A@mail.gmail.com>
 <1403087119.1984.93.camel@x220>
 <CAHNKnsSfaT7xC5_wv=TrGLEQ2pjC91Q1XG891_n64OuR0fA9Jg@mail.gmail.com>
 <1403091974.1984.102.camel@x220> <1409911856.7832.9.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: openwrt-devel@lists.openwrt.org, Jiri Slaby <jirislaby@gmail.com>,
 open@hauke-m.de, Richard Weinberger <richard@nod.at>,
 ath5k-devel@venema.h4ckr.net, linux-wireless@vger.kernel.org,
 "John W. Linville" <linville@tuxdriver.com>,
 Oleksij Rempel <linux@rempel-privat.de>, netdev@vger.kernel.org,
 Nick Kossifidis <mickflemm@gmail.com>, Hauke Mehrtens <hauke@hauke-m.de>,
 list@hauke-m.de, linux-kernel@vger.kernel.org, antonynpavlov@gmail.com
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <openwrt-devel-bounces@lists.openwrt.org>
In-Reply-To: <1409911856.7832.9.camel@x220>
List-Unsubscribe: <https://lists.openwrt.org/cgi-bin/mailman/options/openwrt-devel>,
 <mailto:openwrt-devel-request@lists.openwrt.org?subject=unsubscribe>
List-Archive: <http://lists.openwrt.org/pipermail/openwrt-devel/>
List-Post: <mailto:openwrt-devel@lists.openwrt.org>
List-Help: <mailto:openwrt-devel-request@lists.openwrt.org?subject=help>
List-Subscribe: <https://lists.openwrt.org/cgi-bin/mailman/listinfo/openwrt-devel>,
 <mailto:openwrt-devel-request@lists.openwrt.org?subject=subscribe>
Errors-To: openwrt-devel-bounces@lists.openwrt.org
Sender: "openwrt-devel" <openwrt-devel-bounces@lists.openwrt.org>
List-Id: netdev.vger.kernel.org

Hello Paul,

2014-09-05 14:10 GMT+04:00, Paul Bolle <pebolle@tiscali.nl>:
> Jiri, Nick, Luis, John,
>
> On Wed, 2014-06-18 at 13:46 +0200, Paul Bolle wrote:
>> Having this conversation every rc1 is getting a bit silly. Could Jiri
>> e.a. perhaps set some specific deadline for ATHEROS_AR231X to be
>> submitted?
>
> I waited until rc3. Have you seen any activity on this front? If not,
> should I resend the patch that removes the code in mainline that depends
> on ATHEROS_AR231X (ie, AHB bus support)?
>
Recent activity always could be found in [1]. Now I finish another one
round of cleanups and have a plan to fix several things (you can
always find something that you really want to improve). But if you
insist I could immediately switch to "send upstream" mode. And seems
that this would be better approach.

1. https://dev.openwrt.org/log/trunk/target/linux/atheros

-- 
BR,
Sergey
