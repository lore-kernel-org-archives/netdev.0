From: "Thiago Lacerda" <thiagotbl@gmail.com>
Subject: Questions about Linux kernel network programming
Date: Thu, 28 Aug 2008 11:48:52 -0300
Message-ID: <3fedcc3b0808280748q4090c5e7n45c74c4fd3b42cca@mail.gmail.com>
References: <3fedcc3b0808280733w1d7b24dgf95540d2078856f8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:42696 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755049AbYH1Osx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 10:48:53 -0400
Received: by gxk9 with SMTP id 9so4651974gxk.13
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2008 07:48:52 -0700 (PDT)
In-Reply-To: <3fedcc3b0808280733w1d7b24dgf95540d2078856f8@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone, I'm a Computer Science student from Brazil.

Hope that you can help me with my undergraduate conclusion project.

I have to capture packets at kernel level. More specifically, I have
to write a kernel module (for kernel 2.6) that access all the packets
that are coming through my network interface, then perform some
operations on that packets and then decide if they can go to user land
or not.

Please note that I can't do it as a firewall, because I can't
interfere on the  applications that  work with network. My kernel
module will get communicated with traffic classifier, that will be
executing at user land and will inspect the packets that the module
passed to it.

Can you help me on how can I develop it?

Thanks in advance

Best regards


-- 
Thiago de Barros Lacerda
Computer Science Undergraduate Student - CIn/UFPE - 2004.2
Researcher/Software Developer - GPRT - Networking and
Telecommunications Research Group
