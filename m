From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: virtio_net: remove recv refill work?
Date: Thu, 10 Mar 2011 13:22:45 -0800
Message-ID: <1299792165.25664.215.camel@localhost.localdomain>
References: <1299791038.25664.213.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:44412 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077Ab1CJVWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 16:22:48 -0500
In-Reply-To: <1299791038.25664.213.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Never mind, the refill work is needed only for OOM. It can't be
replaced.

thanks
Shirley

