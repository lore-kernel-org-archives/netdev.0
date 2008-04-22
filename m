From: "=?UTF-8?Q?Rui_Tiago_Ca=C3=A7=C3=A3o_Matos?=" <rmatos@av.it.pt>
Subject: Re: [PATCH] Add tcindex classifier
Date: Tue, 22 Apr 2008 16:42:51 +0100
Message-ID: <eae3b3410804220842i3525a932w465e14299dd6b2f1@mail.gmail.com>
References: <-1382474018225740310@unknownmsgid>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: "Rui T. Matos" <rmatos@hng.av.it.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.234]:52991 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764315AbYDVPmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 11:42:53 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1838954wxd.4
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 08:42:52 -0700 (PDT)
In-Reply-To: <-1382474018225740310@unknownmsgid>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ That email should have had this text ]

This is a request for comments patch to add support for the tcindex
classifier to libnl.

It lacks support for the police and action attributes and the dump callbacks
aren't implementend since I don't know what to output exactly on each one.

Please comment.

Thanks,
Rui
