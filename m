From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v3 4/7] Add the no SACK route option feature
Date: Mon, 26 Oct 2009 12:38:33 -0400
Message-ID: <4AE5D089.2050606@gmail.com>
References: <1256544393-12450-1-git-send-email-gilad@codefidence.com> <1256544393-12450-5-git-send-email-gilad@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ori@comsleep.com
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:12266 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753744AbZJZQif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 12:38:35 -0400
Received: by ey-out-2122.google.com with SMTP id 9so2423322eyd.19
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2009 09:38:39 -0700 (PDT)
In-Reply-To: <1256544393-12450-5-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gilad Ben-Yossef wrote:
> Implement querying and acting upon the no sack bit in the features
> field.
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
> Sigend-off-by: Ori Finkelman <ori@comsleep.com>
> Sigend-off-by: Yony Amit <yony@comsleep.com>
> 
Please explain how this code turns SACK on when it is off globally?

As both Eric and I asked?
