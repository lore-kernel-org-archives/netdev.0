From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 0/6] Open vSwitch updates
Date: Fri, 29 Mar 2013 18:52:28 -0700
Message-ID: <CAEP_g=9y0-3z8hDz9VAWOK0oh-2RVQNbz+6Lfx_Lp31HBB7nMA@mail.gmail.com>
References: <cover.1364563346.git.tgraf@suug.ch>
	<20130329.155215.2019739910321301961.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2089759664=="
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20130329.155215.2019739910321301961.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

--===============2089759664==
Content-Type: multipart/alternative; boundary=e89a8f22c5bd1b267404d91aa5e0

--e89a8f22c5bd1b267404d91aa5e0
Content-Type: text/plain; charset=UTF-8

On Fri, Mar 29, 2013 at 12:52 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:

> From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
> Date: Fri, 29 Mar 2013 14:46:46 +0100
>
> > A couple of small Open vSwitch fixes and cleanups that accumulated
> > while working on larger pieces.
> >
> > The biggest change is the exposure of <linux/openvswitch.h> to user
> > space to make the Netlink interface available without requiring every
> > appliation to copy the header file from a source tree.
>
> Jesse, I'm assuming you will take these into your tree and then submit
> them to me in an expediant manner? :-)
>

Yes, I'll take care of it.

--e89a8f22c5bd1b267404d91aa5e0
Content-Type: text/html; charset=UTF-8

<div dir="ltr">On Fri, Mar 29, 2013 at 12:52 PM, David Miller <span dir="ltr">&lt;<a href="mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" target="_blank">davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org</a>&gt;</span> wrote:<br><div class="gmail_extra"><div class="gmail_quote">

<blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">From: Thomas Graf &lt;<a href="mailto:tgraf-G/eBtMaohhA@public.gmane.org">tgraf-G/eBtMaohhA@public.gmane.org</a>&gt;<br>
Date: Fri, 29 Mar 2013 14:46:46 +0100<br>
<div class="im"><br>
&gt; A couple of small Open vSwitch fixes and cleanups that accumulated<br>
&gt; while working on larger pieces.<br>
&gt;<br>
&gt; The biggest change is the exposure of &lt;linux/openvswitch.h&gt; to user<br>
&gt; space to make the Netlink interface available without requiring every<br>
&gt; appliation to copy the header file from a source tree.<br>
<br>
</div>Jesse, I&#39;m assuming you will take these into your tree and then submit<br>
them to me in an expediant manner? :-)<br>
</blockquote></div><br></div><div class="gmail_extra" style>Yes, I&#39;ll take care of it.</div></div>

--e89a8f22c5bd1b267404d91aa5e0--

--===============2089759664==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============2089759664==--
