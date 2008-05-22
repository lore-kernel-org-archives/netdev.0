From: Konrad Rzeszutek <konrad-/HHyZTb1IPUUqSzUVP1SBw@public.gmane.org>
Subject: Re: [PATCH 1/3] bnx2: Add support for CNIC driver.
Date: Thu, 22 May 2008 11:18:22 -0400
Message-ID: <20080522151822.GB27897@mars.virtualiron.com>
References: <1211418386-18203-1-git-send-email-mchan@broadcom.com> <1211418386-18203-2-git-send-email-mchan@broadcom.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org, anilgv-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michael Chan <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <grbounce-FC1hwAUAAAA0O9VQcsxVj1UPjHD9r3x_=glio-open-iscsi=m.gmane.org-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1211418386-18203-2-git-send-email-mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <mailto:open-iscsi-help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://googlegroups.com/group/open-iscsi/subscribe>,
	<mailto:open-iscsi-unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


> +static void
> +bnx2_cnic_stop(struct bnx2 *bp)

The preceding functions follow this format:
static void <fnc name>(<args)

While this and some below follow the
static void
<fnc name>(<args>)

You probably want to follow one style.
