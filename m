From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Issue with LACP mode support in Linux bonding driver
Date: Fri, 26 Jun 2015 17:02:11 -0700
Message-ID: <558DE803.60108@hp.com>
References: <CADAe=+LERY5jgVLpVdteFQXhcJdHzNxJpj=9t7Nyf0YTmSXcYQ@mail.gmail.com> <CADAe=+LV=qxt1fwxJdvz6ODScDGGUpmA0YE+mPKZE4C2X0sqUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Ajith Adapa <adapa.ajith@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:54622 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbbF0ACN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 20:02:13 -0400
In-Reply-To: <CADAe=+LV=qxt1fwxJdvz6ODScDGGUpmA0YE+mPKZE4C2X0sqUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/25/2015 06:37 PM, Ajith Adapa wrote:
> Hi,
>
> How can I know the current maintainer for Linux Bonding Driver ?

You can look in the MAINTAINERS file in a current source-tree:


BONDING DRIVER
M:      Jay Vosburgh <j.vosburgh@gmail.com>
M:      Veaceslav Falico <vfalico@gmail.com>
M:      Andy Gospodarek <gospo@cumulusnetworks.com>
L:      netdev@vger.kernel.org
W:      http://sourceforge.net/projects/bonding/
S:      Supported
F:      drivers/net/bonding/
F:      include/uapi/linux/if_bonding.h

Those "M:" entries give the maintainer(s)/people who should be cc'd on 
patches.  Further format explanation can be found in the beginning few 
"pages" of the file.

rick jones
