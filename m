From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v2 2/9] geneve: Use skb mark and protocol to
 lookup route.
Date: Tue, 18 Aug 2015 17:12:34 -0700
Message-ID: <CAEP_g=-WsmBSATe8hNSAO3WP5dsQioqcnAcMdUXhDYWEnvKCsQ@mail.gmail.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com> <1439845905-31666-3-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:33129 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157AbbHSAMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 20:12:55 -0400
Received: by lalv9 with SMTP id v9so109657720lal.0
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 17:12:54 -0700 (PDT)
In-Reply-To: <1439845905-31666-3-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 17, 2015 at 2:11 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> On packet transmit path geneve need to lookup route. Following
> patch improves route lookup using more parameters.
>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Reviewed-by: Jesse Gross <jesse@nicira.com>
