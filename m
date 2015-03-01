From: Jonathon Reinhart <jonathon.reinhart@gmail.com>
Subject: Re: [PATCH iproute2] ip tap: Simplify add 'tap' device w/o mode
Date: Sun, 1 Mar 2015 17:13:39 -0500
Message-ID: <CAPFHKze1coUHyfD_=BKCnXLoLUvbpspcTCHyLGbxmGM0h0QwdA@mail.gmail.com>
References: <1425117586-21461-1-git-send-email-vadim4j@gmail.com> <20150301140715.0a2c7ef2@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vadim Kochan <vadim4j@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:45279 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbbCAWOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 17:14:11 -0500
Received: by wesp10 with SMTP id p10so27779687wes.12
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 14:14:09 -0800 (PST)
In-Reply-To: <20150301140715.0a2c7ef2@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 1, 2015 at 5:07 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> No. mode should not depend on device name.

Isn't this looking at the "tap" part of "ip tap", not the device name?
