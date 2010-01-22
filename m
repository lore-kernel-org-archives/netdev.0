From: Sen Horak <sen.horak@gmail.com>
Subject: netns question - moving physical devices between network spaces
Date: Fri, 22 Jan 2010 17:12:44 -0500
Message-ID: <a80eebd41001221412i56a391dfs565821914c3dc5a8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f209.google.com ([209.85.219.209]:55498 "EHLO
	mail-ew0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753169Ab0AVWMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 17:12:47 -0500
Received: by ewy1 with SMTP id 1so1828353ewy.28
        for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 14:12:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

A while ago I had posted on the lxc mailing list and was told that
with the latest sysfs patch, physical devices could not be moved into
a new netns. Is this always the case, and if so, then is there a
work-in-progress patch that one could play with?

Thanks very much,
Sen
