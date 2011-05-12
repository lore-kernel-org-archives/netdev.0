From: Chin Shi Hong <cshong87@gmail.com>
Subject: ifreq flags or ioctl calls to turn an interface down?
Date: Thu, 12 May 2011 21:27:41 +0800
Message-ID: <BANLkTim=DPqz+pS3DDHw=C4MGMJmu6t=GA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:33788 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755540Ab1ELN1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 09:27:42 -0400
Received: by ewy4 with SMTP id 4so420229ewy.19
        for <netdev@vger.kernel.org>; Thu, 12 May 2011 06:27:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear all,

I am developing an application that will turn a network interface down
(something like command "ifconfig <network interface> down".

What are the ifreq flags or ioctl calls to turn a network interface down?

Or is there any other way to implement this feature into my application?
