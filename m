From: Tomas Winkler <tomasw@gmail.com>
Subject: Re: [PATCH 1/1] iwmc3200: add more SDIO device ids
Date: Tue, 25 Aug 2009 01:20:14 +0300
Message-ID: <1ba2fa240908241520q5be2060co145ec0745954dcf0@mail.gmail.com>
References: <1251149659-32212-1-git-send-email-tomas.winkler@intel.com>
	 <43e72e890908241436o5f30cfe6xa7bdda8b25ac082@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, Greg KH <greg@kroah.com>
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:54601 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753476AbZHXWUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 18:20:13 -0400
In-Reply-To: <43e72e890908241436o5f30cfe6xa7bdda8b25ac082@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2009 at 12:36 AM, Luis R. Rodriguez<mcgrof@gmail.com> wrote:
> On Mon, Aug 24, 2009 at 2:34 PM, Tomas Winkler<tomas.winkler@intel.com> wrote:
>> add WiFi BGN SKU and WiMAX 2.4GHz SKU device ids
>>
>> Cc:inaky.perez-gonzalez@intel.com
>> Cc:cindy.h.kao@intel.com
>> Cc:yi.zhu@intel.com
>> Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
>
> Since it seems we are preferring to not do this for PCI for cases
> where the ID will only be used for 1 device perhaps its best to remove
> all those ids and stuff them directly into the intel driver itself
> that will use it.
>
I don't have strong opinion about it but this is the current habit
IIRC there was a mail thread that explicitly asked to move SDIO IDs
there,  of course I cannot locate it right now :(

Thanks
Tomas
