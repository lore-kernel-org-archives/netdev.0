From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v4] openvswitch: enable NSH support
Date: Fri, 18 Aug 2017 15:31:03 +0200
Message-ID: <20170818153103.5a757abe@griffin>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
	<20170818152601.3760aaec@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, e@erig.me
To: Yi Yang <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170818152601.3760aaec@griffin>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 18 Aug 2017 15:26:01 +0200, Jiri Benc wrote:
> Out of time for today, will continue the review next week. Again, feel
> free to send a new version meanwhile or wait for the rest of the
> review, whatever works better for you.

One more thing: before you send a new version, be sure and double check
that you addressed *all* of the feedback. In this version, you still
have not addressed a few things I gave feedback on in the previous
version. This wastes everyone's time.

It doesn't mean I'm always right, of course, but you either explain why
I'm wrong or change the code. It's generally not acceptable to ignore
feedback.

Thank you,

 Jiri
