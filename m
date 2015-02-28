From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] bridge link: add support to specify master
Date: Fri, 27 Feb 2015 18:58:46 -0800
Message-ID: <20150227185846.72e3b7da@urahara>
References: <1424938379-10716-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com, davem@davemloft.net,
	sfeldma@gmail.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:40015 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbbB1C6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 21:58:46 -0500
Received: by igal13 with SMTP id l13so5282915iga.5
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 18:58:46 -0800 (PST)
In-Reply-To: <1424938379-10716-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Feb 2015 00:12:59 -0800
roopa@cumulusnetworks.com wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch adds support to specify 'master' keyword,
> to target a bridge link command explicitly to the software
> bridge driver.
> 
> Adds self/master keywords to usage and man page
> 
> v2:
> 	fix usage to say (self and master) and not (self or master)
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied
