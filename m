From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: skbuff bug?
Date: Tue, 26 Aug 2008 09:37:59 -0700
Message-ID: <86802c440808260937y4a3e87dt4a897a05dc7fa7b@mail.gmail.com>
References: <86802c440808202056j6cfe5ca0v6284140ae4b9b8cd@mail.gmail.com>
	 <86802c440808211646y758cfdd7n505777b2b8b58c9a@mail.gmail.com>
	 <20080826091752.GB5822@2ka.mipt.ru>
	 <9929d2390808260317l2fb17bcxe099e85fcf5bb939@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"David Miller" <davem@davemloft.net>,
	"Jeff Garzik" <jeff@garzik.org>, "Ingo Molnar" <mingo@elte.hu>,
	"Bruce Allan" <bruce.w.allan@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
To: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:62340 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756812AbYHZQh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 12:37:59 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2211836rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 09:37:59 -0700 (PDT)
In-Reply-To: <9929d2390808260317l2fb17bcxe099e85fcf5bb939@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 26, 2008 at 3:17 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> On Tue, Aug 26, 2008 at 2:17 AM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
>> Hi.
>>
>> On Thu, Aug 21, 2008 at 04:46:49PM -0700, Yinghai Lu (yhlu.kernel@gmail.com) wrote:
>>> it seems caused by
>>>
>>> commit f8d59f7826aa73c5e7682fbed6db38020635d466
>>> Author: Bruce Allan <bruce.w.allan@intel.com>
>>> Date:   Fri Aug 8 18:36:11 2008 -0700
>>>
>>>     e1000e: test for unusable MSI support
>>
>> Intel folks seems to be on vacations or whatever else without access to
>> the mail. Can you confirm that bug still exists in the latest tree and
>> reverting this commit fixes the problem?
>>
>> --
>>        Evgeniy Polyakov
>> --
>
> We are looking into the issue, I am sorry there has been no response until now.
>
> I am still curious if you still see the issue with all the recent
> changes.  Please provide the device id you are using and system info
> so that we can try and reproduce the issue, if the issue persists with
> the latest git tree.

can not duplicate any more...

YH
