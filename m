From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPSec: Use of "sizeof" for header sizes, part II
Date: Wed, 02 Apr 2003 13:20:34 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030402.132034.126030996.yoshfuji@linux-ipv6.org>
References: <20030401.193429.64279267.davem@redhat.com>
	<20030402.130232.78951283.yoshfuji@linux-ipv6.org>
	<20030401.200225.88014087.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: toml@us.ibm.com, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru,
   yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030401.200225.88014087.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030401.200225.88014087.davem@redhat.com> (at Tue, 01 Apr 2003 20:02:25 -0800 (PST)), "David S. Miller" <davem@redhat.com> says:

> I just checked, nobody cares about the 8 bytes in enc_data.
> 
> Therefore, I think you're idea of enc_data[0] is the best.
> 
> Someone please double check my claims and submit a patch. :-)

Okay, I'll check it (and make a patch) in this afternoon 
(in a few hours).

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
