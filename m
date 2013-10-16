From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2.43 0/5] MPLS actions and matches
Date: Wed, 16 Oct 2013 13:21:22 -0700
Message-ID: <CAEP_g=-yCas_3MRY0VrP-W6hOi4wRYNW7=8HEB0GYOp--WU60A@mail.gmail.com>
References: <1381132847-12589-1-git-send-email-horms@verge.net.au>
	<20131010003139.GA20311@verge.net.au>
	<20131016035530.GA29165@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20131016035530.GA29165-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

On Tue, Oct 15, 2013 at 8:55 PM, Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
> On Thu, Oct 10, 2013 at 09:31:41AM +0900, Simon Horman wrote:
>> I believe this series addresses the feedback that each of you
>> gave with regards to recent previous postings of this patch-set.
>> I'm wondering if you could find some time to review it.
>
> I'm waiting for an ack from Jesse, then I'm going to do a final pass and
> I hope to commit this series at this point.  I see some ways that we can
> improve MPLS support afterward but I don't see any blockers.

I guess that we had a deadlock as I was waiting for you. I though that
maybe you would commit the rest of the userspace patches and then I
would just pick up the last two.
