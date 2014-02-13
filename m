From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: RFC: bridge get fdb by bridge device
Date: Thu, 13 Feb 2014 10:37:03 -0500
Message-ID: <52FCE69F.5080602@mojatatu.com>
References: <52F21F72.2090405@mojatatu.com> <52F29747.7040008@redhat.com> <52F3CF76.9090404@mojatatu.com> <52F3E357.4040006@redhat.com> <52F79990.3000400@mojatatu.com> <52F8FEF1.60407@redhat.com> <52FA58E9.906@mojatatu.com> <52FA6A24.3030402@redhat.com> <52FA84FA.2030608@mojatatu.com> <52FA8865.1070302@intel.com> <52FA9074.2060900@mojatatu.com> <52FBC282.6020301@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:32958 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026AbaBMPhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 10:37:05 -0500
Received: by mail-ig0-f180.google.com with SMTP id m12so13080920iga.1
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 07:37:05 -0800 (PST)
In-Reply-To: <52FBC282.6020301@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/14 13:50, John Fastabend wrote:
> On 2/11/2014 1:04 PM, Jamal Hadi Salim wrote:
>
> Because it is not the same type of object as the software bridge.
> Most notably it doesn't do learning.

This kept nagging at me.
Learning is optional for a bridge. So is flooding.
I think we got this right in recent kernels.

cheers,
jamal
