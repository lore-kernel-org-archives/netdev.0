From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH/RFC net] ipv6: fix fragmentation bug
Date: Mon, 4 Nov 2013 17:46:56 +0800
Message-ID: <52776D10.4020104@windriver.com>
References: <1383557174-19424-1-git-send-email-alex.aring@gmail.com> <1383557174-19424-2-git-send-email-alex.aring@gmail.com> <52776B5A.6030701@windriver.com> <20131104094303.GA20131@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<netdev@vger.kernel.org>
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:42201 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488Ab3KDJqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 04:46:30 -0500
In-Reply-To: <20131104094303.GA20131@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B411=E6=9C=8804=E6=97=A5 17:43, Alexander Aring wrote:
> Hi,
>
> On Mon, Nov 04, 2013 at 05:39:38PM +0800, Fan Du wrote:
>> >  Hi, Alexander
>> >
>> >  I don't know whether which head commit you are sitting, this issu=
e might has already been fixed by Steffen:
>> >  https://git.kernel.org/cgit/linux/kernel/git/klassert/ipsec.git/c=
ommit/?id=3D84502b5ef9849a9694673b15c31bd3ac693010ae
>> >
>> >
> oh I am using current net-next which haven't this fix.
>

Since it's a bug fix, so it's in net tree for the moment...

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
