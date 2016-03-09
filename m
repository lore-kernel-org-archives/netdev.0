From: Peter Korsgaard <peter@korsgaard.com>
Subject: Re: [PATCH 1/1] dm9601: enable EP3 interrupt and enhance eeprom functions
Date: Wed, 09 Mar 2016 10:07:00 +0100
Message-ID: <87h9gg2f63.fsf@dell.be.48ers.dk>
References: <1457512657-15352-1-git-send-email-josright123@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Korsgaard <jacmet@sunsite.dk>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joseph CHANG <josright123@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35162 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbcCIJHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 04:07:04 -0500
In-Reply-To: <1457512657-15352-1-git-send-email-josright123@gmail.com> (Joseph
	CHANG's message of "Wed, 9 Mar 2016 16:37:37 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Joseph" == Joseph CHANG <josright123@gmail.com> writes:

Hi Joseph,

 > Enable chip's EP3 interrupt to get the link-up notify soon
 > immediately.

 > Add to maintain variant eeprom adapters which may have not right
 > dm9620x's format.

 > Add function dm9601_set_eeprom which tested good with ethtool
 > utility.

Thanks for the patch. This sounds like 3 seperate changes, could you
please restructure it as 3 patches each doing one of the changes?

-- 
Bye, Peter Korsgaard
