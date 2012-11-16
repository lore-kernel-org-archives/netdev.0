From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 4/9] net: openvswitch: use this_cpu_ptr
	per-cpu helper
Date: Fri, 16 Nov 2012 13:53:45 -0800
Message-ID: <CAEP_g=9bP9iQv=59wYv32ppOhftpsarJM9ET3U9jDxwvatdbQg@mail.gmail.com>
References: <50A1A7D9.2040506@gmail.com> <50A5FAEB.7090202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel-Maillist <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Shan Wei <shanwei88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <50A5FAEB.7090202-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

On Fri, Nov 16, 2012 at 12:35 AM, Shan Wei <shanwei88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Shan Wei said, at 2012/11/13 9:52:
>> From: Shan Wei <davidshan-1Nz4purKYjRBDgjK7y7TUQ@public.gmane.org>
>>
>> just use more faster this_cpu_ptr instead of per_cpu_ptr(p, smp_processor_id());
>>
>>
>> Signed-off-by: Shan Wei <davidshan-1Nz4purKYjRBDgjK7y7TUQ@public.gmane.org>
>> Reviewed-by: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
>
> Jesse Gross,  would you like to pick it up to your tree?

Applied, thanks.
