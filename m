From: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>
Subject: Re: [BUG] tg3 module problem on Linux-2.6.29-rc1-2
Date: Tue, 27 Jan 2009 12:00:43 +0530
Message-ID: <3f9a31f40901262230s3efb9242jcd4a02ee84944daa@mail.gmail.com>
References: <49771D65.3090205@turknet.net.tr>
	 <20090121152818.GA3438@x200.localdomain>
	 <497870A3.4070200@turknet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org,
	David Woodhouse <dwmw2@infradead.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Tarkan Erimer <tarkan.erimer@turknet.net.tr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:41988 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbZA0Gao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 01:30:44 -0500
In-Reply-To: <497870A3.4070200@turknet.net.tr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2009 at 6:42 PM, Tarkan Erimer
<tarkan.erimer@turknet.net.tr> wrote:
> Alexey Dobriyan wrote:
>>
>> # CONFIG_FIRMWARE_IN_KERNEL is not set
>>
>> Try setting this option to =y.
>>
>
> Thanks for the reply. I tried with "CONFIG_FIRMWARE_IN_KERNEL=y" as you
> suggested. But, still I get the same warning.
> It looks like ubuntu's make-kpkg utility or kernel compile process do not
> care about "CONFIG_FIRMWARE_IN_KERNEL=y" and still building modules without
> firmware built-in.
>
>

Is this ubuntu's specific problem or you also getting these
warnings/errors on another releases.

--
JSR
