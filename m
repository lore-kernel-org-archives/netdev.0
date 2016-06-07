From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [PATCHv3 net 2/3] net: cls_u32: be more strict about skip-sw
 flag
Date: Tue, 07 Jun 2016 15:36:06 -0700
Message-ID: <57574C56.4030109@intel.com>
References: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com> <1465337823-16096-1-git-send-email-jakub.kicinski@netronome.com> <1465337823-16096-3-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35964 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423396AbcFGWgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 18:36:08 -0400
In-Reply-To: <1465337823-16096-3-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 6/7/2016 3:17 PM, Jakub Kicinski wrote:
> Return an error if user requested skip-sw and the underlaying
> hardware cannot handle tc offloads (or offloads are disabled).
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>
> ---
> v2:
>    - handle both knode and hnodes
> ---

Acked-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
