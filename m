From: Sam Leffler <sam@errno.com>
Subject: Re: [PATCH Linux-2.6.7-bk19] prism54 freq to
	channel incorrect for 5GHz
Date: Tue, 6 Jul 2004 08:50:49 -0700
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200407060850.49552.sam@errno.com>
References: <200407061738.07098.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: margitsw@t-online.de (Margit Schubert-While)
In-Reply-To: <200407061738.07098.margitsw@t-online.de>
Content-Disposition: inline
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

On Tuesday 06 July 2004 08:38 am, Margit Schubert-While wrote:
> 2004-07-06 Margit Schubert-While <margitsw@t-online.de>
>
> * The frequency to channel conversion is wrong for the 5GHz band
> * Although the (known) devices don't/can't use it,
>   they do report it. (iwlist ethX freq)

There is known good code to do this in the madwifi net80211 layer.

	Sam
