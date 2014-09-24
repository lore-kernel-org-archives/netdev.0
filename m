From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [PATCH/RFC repost 5/8] datapath: Move last_action()
 helper to datapath.h
Date: Wed, 24 Sep 2014 09:20:15 +0100
Message-ID: <20140924082015.GC24298@casper.infradead.org>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
 <1411005311-11752-6-git-send-email-simon.horman@netronome.com>
 <20140919140638.GC8257@casper.infradead.org>
 <20140924060013.GB13314@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140924060013.GB13314-IxS8c3vjKQDk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 09/24/14 at 03:00pm, Simon Horman wrote:
> On Fri, Sep 19, 2014 at 03:06:38PM +0100, Thomas Graf wrote:
> > Can we rename & move this to <net/netlink.h> instead?
> 
> Sure, how about nla_is_last()?

Sounds great
