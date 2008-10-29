From: "Changli Gao" <xiaosuo@gmail.com>
Subject: Re: [PATCH] HTB updates class's bstats in one place
Date: Wed, 29 Oct 2008 17:09:18 +0800
Message-ID: <412e6f7f0810290209wa70b478p8beb8c3442b9fa82@mail.gmail.com>
References: <490824B3.20100@gmail.com> <4908264D.4030206@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:16152 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752876AbYJ2JJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 05:09:19 -0400
Received: by rv-out-0506.google.com with SMTP id k40so3196881rvb.1
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 02:09:18 -0700 (PDT)
In-Reply-To: <4908264D.4030206@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 5:01 PM, Patrick McHardy <kaber@trash.net> wrote:
> The estimators needs
> this since they're estimating the arrival rate.
>
>
I do not agree with you. TC is only for sending packets. Why does its
estimator estimating the arrival rate?
-- 
Regards，
Changli Gao(xiaosuo@gmail.com)
