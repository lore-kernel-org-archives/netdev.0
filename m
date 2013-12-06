From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [net 5/6] drivers/net/*: Fix FSF address in file headers
Date: Fri, 6 Dec 2013 17:29:34 +0000
Message-ID: <424cba8302314ebd8f3bc6af170146c3@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1386340128-23397-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1386340128-23397-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	KY Srinivasan <kys@microsoft.com>,
	Paul Mackerras <paulus@samba.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na01-by1-obe.ptr.o365filtering.com ([64.4.22.87]:58783 "EHLO
	na01-by1-obe.outbound.o365filtering.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754779Ab3LFSEs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 13:04:48 -0500
In-Reply-To: <1386340128-23397-5-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Jeff Kirsher [mailto:jeffrey.t.kirsher@intel.com]
> Sent: Friday, December 6, 2013 9:29 AM
> To: davem@davemloft.net
> Cc: Jeff Kirsher; netdev@vger.kernel.org; gospo@redhat.com;
> sassmann@redhat.com; Jay Vosburgh; Veaceslav Falico; Andy Gospodarek;
> Haiyang Zhang; KY Srinivasan; Paul Mackerras; Ian Campbell; Wei Liu; Rusty
> Russell; Michael S. Tsirkin
> Subject: [net 5/6] drivers/net/*: Fix FSF address in file headers
> 
> Several files refer to an old address for the Free Software Foundation
> in the file header comment.  Resolve by replacing the address with
> the URL <http://www.gnu.org/licenses/> so that we do not have to keep
> updating the header comments anytime the address changes.
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Veaceslav Falico <vfalico@redhat.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: Haiyang Zhang <haiyangz@microsoft.com>
> CC: "K. Y. Srinivasan" <kys@microsoft.com>
> CC: Paul Mackerras <paulus@samba.org>
> CC: Ian Campbell <ian.campbell@citrix.com>
> CC: Wei Liu <wei.liu2@citrix.com>
> CC: Rusty Russell <rusty@rustcorp.com.au>
> CC: "Michael S. Tsirkin" <mst@redhat.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Acked-by: Haiyang Zhang <haiyangz@microsoft.com>
