From: "Rajahalme, Jarno (NSN - FI/Espoo)" <jarno.rajahalme-OYasijW0DpE@public.gmane.org>
Subject: Re: [PATCH] datapath: Add basic MPLS support to kernel
Date: Thu, 25 Apr 2013 11:28:18 +0000
Message-ID: <FCE0ACEF-2204-494C-9DC7-31E8B79E356A@nsn.com>
References: <1366876738-29688-1-git-send-email-horms@verge.net.au>
	<A52D2BF3-6A9D-42B5-B52F-0F9FC7A50D61@nsn.com>
	<20130425110216.GA582@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "<dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: ext Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20130425110216.GA582-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Content-Language: en-US
Content-ID: <833479909F01F64DA71414A1B782755E-z7JfP6tgrtWhxUC7wdWhuQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org


On Apr 25, 2013, at 14:02 , ext Simon Horman wrote:
> 
> Yes, stack_len is supposed to advance by one for each iteration of the loop.

Better make it by four instead ;-)

  Jarno
