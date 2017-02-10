From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/3] ath10k: remove ath10k_vif_to_arvif()
Date: Thu, 09 Feb 2017 23:37:02 -0800
Message-ID: <1486712222.2192.3.camel@perches.com>
References: <1486030773-30600-1-git-send-email-amadeusz.slawinski@tieto.com>
         <CAJ-VmonrHpS3MArM9ohHgLvb6xspP_gnVVeJWA9F-pjUpJ+LZA@mail.gmail.com>
         <87y3xi4b28.fsf@qca.qualcomm.com> <5899DDD7.7000605@candelatech.com>
         <87tw82il32.fsf@kamboji.qca.qualcomm.com>
         <CAJ-Vmom7k3Tsgs8tRHQppmL7XxADS3V24AGOQY5QgkrSgr5Qzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        Amadeusz =?UTF-8?Q?S=C5=82awi=C5=84ski?=
        <amadeusz.slawinski@tieto.com>,
        "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Adrian Chadd <adrian@freebsd.org>,
        "Valo, Kalle" <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJ-Vmom7k3Tsgs8tRHQppmL7XxADS3V24AGOQY5QgkrSgr5Qzg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-02-09 at 23:14 -0800, Adrian Chadd wrote:

> If there
> were accessors for the skb data / len fields (like we do for mbufs)
> then porting the code would've involved about 5,000 less changed
> lines.

What generic mechanisms would you suggest to make
porting easier between bsd and linux and what in
your opinion are the best naming schemes to make
these functions easiest to read and implement
without resorting to excessive identifier lengths?

If you have some, please provide examples.
