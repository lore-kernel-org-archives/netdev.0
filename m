From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@wide.ad.jp>
Subject: Re: IPsecv6 integrity failures not dropped
Date: Sat, 19 Apr 2003 11:17:19 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030419.111719.51896623.yoshfuji@wide.ad.jp>
References: <200304182017.h3IKH4ng019821@faith.austin.ibm.com>
	<20030418.141014.17269641.davem@redhat.com>
	<20030419.111238.07385967.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: latten@austin.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: davem@redhat.com
In-Reply-To: <20030419.111238.07385967.yoshfuji@wide.ad.jp>
List-Id: netdev.vger.kernel.org

In article <20030419.111238.07385967.yoshfuji@wide.ad.jp> (at Sat, 19 Apr 2003 11:12:38 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@wide.ad.jp> says:

>   > 0: more header(s) follows; next header is pointed by skb->nh.raw[nhoff]
                                 next header is pointed by nhoff (which means, the next header is skb->nh.raw[nhoff])

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
