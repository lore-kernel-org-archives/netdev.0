From: Marius Kotsbak <marius.kotsbak@gmail.com>
Subject: Re: Regarding sumbiting a new NIC driver to kernel.
Date: Fri, 01 Jul 2011 13:13:01 +0200
Message-ID: <4E0DABBD.7070809@gmail.com>
References: <6349D7A510622448B1BA0967850A843801163B91@nasanexd02d.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "'davem@davemloft.net'" <'davem@davemloft.net'>,
	"Huang, Xiong" <xiong@qca.qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ren, Cloud" <cjren@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:58358 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132Ab1GALNG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 07:13:06 -0400
Received: by bwd5 with SMTP id 5so2525804bwd.19
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2011 04:13:04 -0700 (PDT)
In-Reply-To: <6349D7A510622448B1BA0967850A843801163B91@nasanexd02d.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Den 01. juli 2011 11:09, skrev Ren, Cloud:
> Would you have any advices to us?  If this is possible, how do I submit the new driver and remove the old driver? Can you give me a doc how to submit the driver to kernel or any hints?

All should be explained in:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=Documentation/SubmittingPatches;h=569f3532e1383cb3e67dcba7b77990b5f18a1411;hb=HEAD

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=Documentation/SubmittingDrivers;h=319baa8b60dd727d82c5e8fa062c13e3bb3126d5;hb=HEAD

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=Documentation/SubmitChecklist;h=da0382daa39556939dcc94717b658b5917e4009f;hb=HEAD

--
Marius


