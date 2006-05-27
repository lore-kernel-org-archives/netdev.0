From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/5] s390: minor fix in cu3088
Date: Fri, 26 May 2006 21:56:56 -0400
Message-ID: <4477B1E8.5040208@pobox.com>
References: <20060524095105.68a65118@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:63971 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751750AbWE0B47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 21:56:59 -0400
To: Frank Pavlic <fpavlic@de.ibm.com>
In-Reply-To: <20060524095105.68a65118@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frank Pavlic wrote:
> Hi Jeff,
> please apply following 5 patches. 
> 
> Thanks ...
> 
> Frank
> 
> From: Cornelia Huck <cornelia.huck@de.ibm.com>
> 
> In case of a parse error for the cu3088 group attribute,
> return -EINVAL instead of count.
> 
> Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>

applied patches 1-3 of 5


