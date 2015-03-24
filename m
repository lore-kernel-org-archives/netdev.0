From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/2] ip: Make uniform the use of synonyms list,
 show and lst
Date: Tue, 24 Mar 2015 14:49:56 -0700
Message-ID: <20150324144956.28d77e7e@urahara>
References: <1426499950-6641-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mark Einon <mark.einon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:32874 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbbCXVty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 17:49:54 -0400
Received: by pdnc3 with SMTP id c3so6352304pdn.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 14:49:53 -0700 (PDT)
In-Reply-To: <1426499950-6641-1-git-send-email-mark.einon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Mar 2015 09:59:09 +0000
Mark Einon <mark.einon@gmail.com> wrote:

> Where used in the ip tool, the 'show' option always has the synonyms
> 'list' and 'lst', except for ip-token and ip-addrlabel, which are missing
> 'lst'. Add this as a synonym for these commands.
> 
> Signed-off-by: Mark Einon <mark.einon@gmail.com>

Applied
