From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 1/2] add bridge_slave device support
Date: Sun, 28 Sep 2014 16:33:57 -0700
Message-ID: <20140928163357.4f69a21d@urahara>
References: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
	<1409925309-17881-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	sfeldma@cumulusnetworks.com, arvid.brodin@alten.se,
	sucheta.chakraborty@qlogic.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:58108 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbaI1XeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 19:34:15 -0400
Received: by mail-pd0-f172.google.com with SMTP id g10so4272632pdj.3
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 16:34:14 -0700 (PDT)
In-Reply-To: <1409925309-17881-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  5 Sep 2014 15:55:08 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> Note this depends on "iproute2: allow to change slave options via
> type_slave"
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

The iproute portion has to go in net-next not master branch of iproute2
