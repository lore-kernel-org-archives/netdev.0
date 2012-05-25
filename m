From: Qasim Javed <qasimj-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] mac80211: Use correct originator sequence number in a Path
	Reply
Date: Fri, 25 May 2012 12:17:34 -0500
Message-ID: <CAJivULpT=XTG2tKm=hQk9mHwJ2K5eo_siHRAWfL0y3vPfrRLiA@mail.gmail.com>
References: <1337934071-29342-1-git-send-email-qasimj@gmail.com>
	<CAEFj985HxSrOwOoevDjG1jxPxobLda-X_LZUtj6LgwXZwozBog@mail.gmail.com>
	<CAJivULpmLp9JK+PQZ9RkrvvYHNk=uA33=A-ffftroigivy1_NQ@mail.gmail.com>
	<CAEFj984efuO12nSPsZ2A0Q0nwPLesYJ8gDHwgh=0e1VO3_UtGw@mail.gmail.com>
	<CAEFj987dNMyMcS9rySzVpfY0Fo5t0LtL9FZg770ohKi+bDO9ZA@mail.gmail.com>
Reply-To: devel-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ravip-DNmUmOh1Rg72fBVCVOL8/A@public.gmane.org
To: Javier Cardona <javier-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>
Return-path: <devel-bounces-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org>
In-Reply-To: <CAEFj987dNMyMcS9rySzVpfY0Fo5t0LtL9FZg770ohKi+bDO9ZA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://lists.open80211s.org/cgi-bin/mailman/options/devel>,
	<mailto:devel-request-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open80211s.org/pipermail/devel>
List-Post: <mailto:devel-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:devel-request-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <http://lists.open80211s.org/cgi-bin/mailman/listinfo/devel>,
	<mailto:devel-request-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: devel-bounces-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org
Errors-To: devel-bounces-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

Forgot to add Javier. Could you please comment on this?

Thanks,
-Qasim

On Fri, May 25, 2012 at 11:31 AM, Yeoh Chun-Yeow <yeohchunyeow-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> I think that the PREQ element has originator sequence number at the
>> end but the PREQ element has the target sequence number at the end.
>> This is what mesh_path_sel_frame_tx is doing.
>
> PREP element has originator sequence number at the end but the PREQ
> element has the target sequence number at the end.
>
> Regards,
> Chun-Yeow
> _______________________________________________
> Devel mailing list
> Devel-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org
> http://lists.open80211s.org/cgi-bin/mailman/listinfo/devel
