From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: Re: [PATCH net-next] IPsec: do not ignore crypto err in ah input
Date: Fri, 13 Jan 2017 08:45:51 +0100
Message-ID: <20170113074551.GA24287@gmail.com>
References: <1484228002-25078-1-git-send-email-gilad@benyossef.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        davem@davemloft.net, netdev@vger.kernel.org, ofir.drang@arm.com,
        gilad.benyossef@arm.com
To: Gilad Ben-Yossef <gilad@benyossef.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37966 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750793AbdAMHp4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 02:45:56 -0500
Received: by mail-wm0-f43.google.com with SMTP id r144so58566936wme.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 23:45:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1484228002-25078-1-git-send-email-gilad@benyossef.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2017 at 03:33:22PM +0200, Gilad Ben-Yossef wrote:
> ah input processing uses the asynchrnous hash crypto API which
> supplies an error code as part of the operation completion but 
> the error code was being ignored.
>
s/asynchrnous/asynchronous

-- 
Mit freundlichen Grüßen

Alexander Alemayhu
