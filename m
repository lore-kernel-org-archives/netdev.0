From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 2/2] dt: bindings: Add bindings for Cirrus Logic CS89x0
 ethernet chip
Date: Tue, 14 Jun 2016 18:33:08 -0500
Message-ID: <20160614233308.GA6128@rob-hp-laptop>
References: <1465833137-836-1-git-send-email-shc_work@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>
To: Alexander Shiyan <shc_work@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35446 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332AbcFNXdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 19:33:10 -0400
Content-Disposition: inline
In-Reply-To: <1465833137-836-1-git-send-email-shc_work@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016 at 06:52:17PM +0300, Alexander Shiyan wrote:
> Add device tree binding documentation details for Cirrus Logic
> CS8900/CS8920 ethernet chip.
> 
> Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
> ---
>  Documentation/devicetree/bindings/net/cirrus,cs89x0.txt | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/cirrus,cs89x0.txt

Acked-by: Rob Herring <robh@kernel.org>
