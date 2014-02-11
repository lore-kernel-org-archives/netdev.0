From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: RFC: bridge get fdb by bridge device
Date: Tue, 11 Feb 2014 16:12:16 -0500
Message-ID: <52FA9230.4070005@mojatatu.com>
References: <52F21F72.2090405@mojatatu.com> <52F29747.7040008@redhat.com> <52F3CF76.9090404@mojatatu.com> <52F3E357.4040006@redhat.com> <52F79990.3000400@mojatatu.com> <52F8FEF1.60407@redhat.com> <52FA58E9.906@mojatatu.com> <52FA6A24.3030402@redhat.com> <52FA84FA.2030608@mojatatu.com> <52FA8F8B.3080500@redhat.com> <52FA9167.2040305@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: vyasevic@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:64338 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140AbaBKVMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 16:12:18 -0500
Received: by mail-ie0-f180.google.com with SMTP id u16so161082iet.39
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 13:12:18 -0800 (PST)
In-Reply-To: <52FA9167.2040305@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/14 16:08, Jamal Hadi Salim wrote:
> On 02/11/14 16:00, Vlad Yasevich wrote:
>> On 02/11/2014 03:15 PM, Jamal Hadi Salim wrote:
>

> I think in one of the modes it is merely a filter.
> But you turn on this other feature it is a bridge.

IOW, VEPA should turn off IFF_BRIDGE and VEB should
turn it on. We probably need an event generated.


cheers,
jamal
