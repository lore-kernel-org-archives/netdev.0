From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPSec: Use of "sizeof" for header sizes, part II
Date: Thu, 03 Apr 2003 04:20:09 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030403.042009.28704472.davem@redhat.com>
References: <OFFFFBD9B7.552E83C4-ON85256CFC.0051D199-86256CFC.00526741@pok.ibm.com>
	<20030403.135104.748509693.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: toml@us.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030403.135104.748509693.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Thu, 03 Apr 2003 13:51:04 +0900 (JST)

   In article <OFFFFBD9B7.552E83C4-ON85256CFC.0051D199-86256CFC.00526741@pok.ibm.com> (at Wed, 2 Apr 2003 09:00:03 -0600), "Tom Lendacky" <toml@us.ibm.com> says:
   
   > 
   > I just noticed the use of the AH_HLEN_NOICV #define which is hardcoded to
   > be 12.  The patch should probably take the change to the esp header and
   > apply it to the auth header also (as shown in an earlier post) and then
   > eliminate the hardcoding of the 12.
   
   Agreed.  Here's the patch against linux-2.5.66 + ChangeSet 1.1004.
   Thanks.

Patch applied, thank you.
