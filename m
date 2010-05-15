From: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: cxgb4i_v3.1 submission
Date: Sat, 15 May 2010 22:54:06 +0530
Message-ID: <1273944249-311-1-git-send-email-rakesh@chelsio.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>,
        Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>, Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
        Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: NETDEVML <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, SCSIDEVML <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        OISCSIML <open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Return-path: <open-iscsi+bncCKnrzee6GxDosbvfBBoEYKbA_A-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post?hl=en_US>,
	<mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/?hl=en_US>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi?hl=en_US>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
	<mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


The following 3 patches add a new iscsi LLD driver cxgb4i to enable iscsi offload
support on Chelsio's new 1G and 10G cards. This is updated version of previous cxgb4i
patch. Please share you commnets after review.

Changes since cxgb4i_v3.1
1. Abastract libcxgbi library common part more properly.
2. Fixed few packet sequence calculation bugs.
3. compile-time initialization of cplhandlers
4. Removed the private mail address from patches from field


[PATCH 1/3] cxgb4i_v3: add build support
[PATCH 2/3] cxgb4i_v3: main driver files
[PATCH 3/3] cxgb4i_v3: iscsi and libcxgbi library for handling common part

Regards
Rakesh Ranjan

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To unsubscribe from this group, send email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi?hl=en.
