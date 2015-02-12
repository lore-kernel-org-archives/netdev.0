From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: btcoex subsystem
Date: Thu, 12 Feb 2015 12:28:46 -0800
Message-ID: <D5A7B08D-EA98-4A6E-A6BF-E19D87B5066A@holtmann.org>
References: <1422304934-9239-1-git-send-email-Larry.Finger@lwfinger.net> <1422304934-9239-6-git-send-email-Larry.Finger@lwfinger.net> <87h9v8zkuh.fsf@kamboji.qca.qualcomm.com> <EC423C22-AEA0-4232-A452-7A131C41780A@holtmann.org> <54CBA0CE.8030800@lwfinger.net> <B814EF26-CBC9-43E4-A6C9-761A013F85C1@holtmann.org> <874mr3xjnx.fsf_-_@kamboji.qca.qualcomm.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2070.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Troy Tan <troy_tan@realsil.com.cn>, netdev@vger.kernel.org,
	linux-bluetooth@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:40256 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043AbbBLU27 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 15:28:59 -0500
In-Reply-To: <874mr3xjnx.fsf_-_@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Kalle,

>>> I will work on combining the latest BT drivers from Realtek with
>>> btusb to see if I can achieve a patch that will both work with the
>>> Realtek hardware, and get approval from the reviewers.
>>> 
>>> What would be an approved method of communicating between two kernel
>>> modules? Is there some example in the kernel that I could study?
>> 
>> We need a btcoex subsystem that both WiFi and Bluetooth can register
>> to and communicate with.
> 
> The need for this seems to periodically come up, I remember needing
> something like that back in the Maemo wl1251 days and also ath6kl needed
> this. Are there any ideas for this subsystem? How would this btcoex
> subsystem work? What kind of information would it provide?
> 
> Is this something we should discuss at Ottawa?

sadly something came up and I am not making it to Ottawa. However we should be talking about this at some point since Bluetooth has MWS for its coexistence which could be a good starting point. Something we have to look into for the Bluetooth subsystem at some point.

Regards

Marcel
