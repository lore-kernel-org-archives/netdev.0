From: Oliver Neukum <oliver@neukum.org>
Subject: future developments of usbnet
Date: Fri, 6 May 2011 20:45:37 +0200
Message-ID: <201105062045.37336.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:38807 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756365Ab1EFTj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 15:39:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'd like to get a feeling what people are working out there regarding usbnet.
So please, if you do something, or think something ought to be done, please
speak up now.

IMHO usbnet needs better support for

- batching protocols
- double buffering on the rx path

with the latter having higher priority.

Coments?

	Regards
		Oliver
