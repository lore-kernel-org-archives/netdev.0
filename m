From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] remove version.h includes in
	net/openvswitch/
Date: Mon, 16 Jan 2012 13:40:01 -0800
Message-ID: <CAEP_g=-2qSjcobw0q0Rp9KUAZC9+PmedCntaXS0JNs7NnnggLw@mail.gmail.com>
References: <1326564981-7142-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Devendra Naga <devendra.aaru-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1326564981-7142-1-git-send-email-devendra.aaru-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

On Sat, Jan 14, 2012 at 10:16 AM, Devendra Naga <devendra.aaru-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> remove version.h includes in net/openswitch/ as reported by make versioncheck.
>
> Signed-off-by: Devendra Naga <devendra.aaru-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

I'm fine with the change (it's just a leftover from the out-of-tree
module), although in general please prefix the subject with the area
that it is modifying.
