From: Joe Perches <joe@perches.com>
Subject: Re: [patch net-next] irda: w83977af_ir: cleanup an indent issue
Date: Mon, 12 Dec 2016 07:22:08 -0800
Message-ID: <1481556128.1764.17.camel@perches.com>
References: <20161212112134.GA10035@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0213.hostedemail.com ([216.40.44.213]:50495 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752366AbcLLPWN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 10:22:13 -0500
In-Reply-To: <20161212112134.GA10035@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-12-12 at 14:21 +0300, Dan Carpenter wrote:
> In commit 99d8d2159d7c ("irda: w83977af_ir: Neaten logging"), we
> accidentally added an extra tab to these lines.

Thanks Dan.

Oops,  It's kinda funny I did the whole
series to fix that misindentation originally
and added it back when rebasing.
