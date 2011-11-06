From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Regarding Routing table in Linux kernel
Date: Sun, 6 Nov 2011 12:43:22 +0530
Message-ID: <CADAe=+J-yjh-GujhVY58qKirGNANQ6fUnPdzvoQzQSxMDv7VPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43647 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856Ab1KFHNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2011 02:13:54 -0500
Received: by faao14 with SMTP id o14so4097677faa.19
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2011 00:13:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have few doubts regarding the routing table in linux kernel.

1. Why does the linux kernel use hashing table for storing routing
entries when there is patricia trie or radix tree which is more faster
than Hash table ?

2. Is there any way we can test the performance of an routing
algorithm before deploying in a real time scenario to check its
performance ? I would like to test one of my implementations to check
if there are any performance gains or not ?

Regards,
Ajith
