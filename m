From: "Jan Beulich" <JBeulich@suse.com>
Subject: RE: [net-next 02/11] e1000: Adding e1000_dump function
Date: Thu, 09 Feb 2012 09:08:18 +0000
Message-ID: <4F339B120200007800071D1F@nat28.tlf.novell.com>
References: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1328618038-5008-3-git-send-email-jeffrey.t.kirsher@intel.com>
 <1782836.alj52xdzPl@alaris>
 <061C8A8601E8EE4CA8D8FD6990CEA89123BDE6@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Jeffrey T Kirsher" <jeffrey.t.kirsher@intel.com>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Michal Kubecek" <mkubecek@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Tushar N Dave" <tushar.n.dave@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:52543 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757510Ab2BIJIZ convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:5:1>);
	Thu, 9 Feb 2012 04:08:25 -0500
In-Reply-To: <061C8A8601E8EE4CA8D8FD6990CEA89123BDE6@ORSMSX102.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 08.02.12 at 19:39, "Dave, Tushar N" <tushar.n.dave@intel.com> wrote:
> Also when running in Xen which arch are you running on?

Currently this can only possibly be x86 (32- or 64-bit), ia64 doesn't
build, and no other ports are available upstream so far.

Jan
