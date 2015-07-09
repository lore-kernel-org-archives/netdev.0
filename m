From: Damian Hobson-Garcia <dhobsong@igel.co.jp>
Subject: Re: [PATCH v3 1/1] eventfd: implementation of EFD_MASK flag
Date: Thu, 9 Jul 2015 18:06:52 +0900
Message-ID: <559E39AC.1010408@igel.co.jp>
References: <1361187290-11759-1-git-send-email-sustrik@250bpm.com>
 <559E296A.6040606@igel.co.jp>
 <8bb2fb10a310dc3e1eddb851aba93054@imap.lucina.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Martin Sustrik <sustrik@250bpm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:33512 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbbGIJGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 05:06:49 -0400
Received: by pdbqm3 with SMTP id qm3so18292356pdb.0
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 02:06:49 -0700 (PDT)
In-Reply-To: <8bb2fb10a310dc3e1eddb851aba93054@imap.lucina.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin,

On 2015-07-09 5:41 PM, Martin Sustrik wrote:
> Hi Damian,
> 
> Yes, this patch would be geneally useful for implementing stuff in user
> space that otherwise would have to live in kernelspace.
> 
> Unfortunately, I have no cycles left to pursue getting it to the
> mainline. If you feel like you can take care of it, that would be great.
I'll see what I can do. I'll rebase it and resubmit it.
Unless there are major changes (which I highly doubt), I'll keep you as
the author, if that's ok with you.
> 
> I can help with the documentation, if needed.
Thank you, that would be very much appreciated.

Damian
